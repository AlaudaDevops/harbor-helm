package steps

import (
	"context"
	"time"

	"github.com/AlaudaDevops/bdd/asserts"
	"github.com/AlaudaDevops/bdd/logger"
	"github.com/AlaudaDevops/bdd/steps/kubernetes/resource"
	"go.uber.org/zap"
)

func stepHarborResourceConditionCheck(ctx context.Context, instanceName string) (context.Context, error) {
	log := logger.LoggerFromContext(ctx)
	checks := getInstanceChecks(ctx, instanceName)
	for _, check := range checks {
		_, err := resource.AssertResource(ctx, check)
		if err != nil {
			log.Error("check harbor component condition failed", zap.Error(err), zap.String("name", check.Name))
			return ctx, err
		}
		log.Info("check harbor component condition success", zap.String("name", check.Name))
	}

	return ctx, nil
}

func getComponentCheck(instanceName, componentName string) resource.Assert {
	return resource.Assert{
		AssertBase: resource.AssertBase{
			Resource: resource.Resource{
				Kind:       "Pod",
				APIVersion: "v1",
				Name:       instanceName + "-" + componentName,
			},
			PathValue: asserts.PathValue{
				Path:  "$.status.conditions[?(@.type == 'Ready')][0].status",
				Value: "True",
			},
		},
		CheckTime: resource.CheckTime{
			Interval: 10 * time.Second,
			Timeout:  10 * time.Minute,
		},
	}
}

func getInstanceChecks(_ context.Context, instanceName string) []resource.Assert {
	return []resource.Assert{
		getComponentCheck(instanceName, "registry"),
		getComponentCheck(instanceName, "trivy"),
		getComponentCheck(instanceName, "core"),
		getComponentCheck(instanceName, "jobservice"),
	}
}
